package geopyspark.netcdf.datasets

import geopyspark.geotrellis.{SpatialTiledRasterRDD, TemporalTiledRasterRDD}

import geotrellis.proj4.LatLng
import geotrellis.raster._
import geotrellis.spark._
import geotrellis.spark.TileLayerMetadata
import geotrellis.spark.tiling.LayoutDefinition
import geotrellis.vector._

import org.apache.spark.api.java.JavaRDD
import org.apache.spark.rdd.RDD
import org.apache.spark.SparkContext

import java.io._

import ucar.nc2._

import scala.collection.JavaConversions._


object Gddp {

  private val millisPerDay: Int = 24 * 60 * 60 * 1000

  private def open(uri: String) = {
    if (uri.startsWith("s3:")) {
      val raf = new ucar.unidata.io.s3.S3RandomAccessFile(uri, 1<<15, 1<<24)
      NetcdfFile.open(raf, uri, null, null)
    } else {
      NetcdfFile.open(uri)
    }
  }

  private def extentToIndices(extent: java.util.ArrayList[Double]): List[Int] = {
    var _xmin = extent.get(0)
    val  ymin = extent.get(1)
    var _xmax = extent.get(2)
    val  ymax = extent.get(3)

    if (_xmin >= 0) _xmin -= 360
    if (_xmax >= 0) _xmax -= 360
    val xmin = if (_xmin < _xmax) _xmin; else _xmax;
    val xmax = if (_xmax > _xmin) _xmax; else _xmin;

    val xSliceStart = math.floor(4 * (xmin - (-360 + 1/8.0))).toInt
    val xSliceStop  = math.ceil( 4 * (xmax - (-360 + 1/8.0))).toInt
    val ySliceStart = math.floor(4 * (ymin - ( -90 + 1/8.0))).toInt
    val ySliceStop  = math.ceil( 4 * (ymax - ( -90 + 1/8.0))).toInt

    List(xSliceStart, xSliceStop, ySliceStart, ySliceStop)
  }

  private def pointToIndices(point: java.util.ArrayList[Double]): List[Int] = {
    var x = point.get(0)
    val y = point.get(1)

    if (x >= 0) x -= 360

    val xSlice = math.round(4 * (x - (-360 + 1/8.0))).toInt
    val ySlice = math.round(4 * (y - ( -90 + 1/8.0))).toInt

    List(xSlice, ySlice)
  }

  def raster(
    netcdfUri: String,
    extent: java.util.ArrayList[Double],
    day: Int
  ): (Int, Int, Array[Float]) = {
    val List(xSliceStart, xSliceStop, ySliceStart, ySliceStop) = extentToIndices(extent)
    val xWidth = xSliceStop - xSliceStart + 1
    val yWidth = ySliceStop - ySliceStart + 1

    val ncfile = open(netcdfUri)
    val tasmin = ncfile.getVariables().get(3)
    val ucarType = tasmin.getDataType()

    val array = tasmin
      .read(s"$day,$ySliceStart:$ySliceStop,$xSliceStart:$xSliceStop")
      .get1DJavaArray(ucarType).asInstanceOf[Array[Float]]
    (xWidth, yWidth, array)
  }

  def rasters(
    netcdfUri: String,
    extent: java.util.ArrayList[Double],
    days: java.util.ArrayList[Int],
    baseInstant: Int,
    sc: SparkContext
  ) = {
    val List(xSliceStart, xSliceStop, ySliceStart, ySliceStop) = extentToIndices(extent)
    val xWidth = xSliceStop - xSliceStart + 1
    val yWidth = ySliceStop - ySliceStart + 1

    val ncfile = open(netcdfUri)
    val tasmin = ncfile.getVariables().get(3)
    val attribs = tasmin.getAttributes()
    val nodata = attribs.get(0).getValues().getFloat(0)

    val rdd: RDD[(SpaceTimeKey, MultibandTile)] =
      sc.parallelize(days.toList)
        .mapPartitions({ itr =>
          val ncfile = open(netcdfUri)
          val tasmin = ncfile.getVariables().get(3)
          val ucarType = tasmin.getDataType()

          itr.map({ t =>
            val key = SpaceTimeKey(0, 0, t*millisPerDay + baseInstant)
            val array = tasmin
              .read(s"$t,$ySliceStart:$ySliceStop,$xSliceStart:$xSliceStop")
              .get1DJavaArray(ucarType).asInstanceOf[Array[Float]]
            val tile = FloatUserDefinedNoDataArrayTile(array, xWidth, yWidth, FloatUserDefinedNoDataCellType(nodata)).rotate180.flipVertical
            val mtile = ArrayMultibandTile(tile)

            (key, mtile)
          })
        })
    val ct = FloatUserDefinedNoDataCellType(nodata)
    val tl = TileLayout(1, 1, xWidth, yWidth)
    val ld = LayoutDefinition(Extent(extent.get(0), extent.get(1), extent.get(2), extent.get(3)), tl)
    val crs = LatLng
    val bounds = KeyBounds[SpaceTimeKey](
      SpaceTimeKey(0, 0, days.get(0)),
      SpaceTimeKey(0, 0, days.get(days.size-1)))
    val metadata: TileLayerMetadata[SpaceTimeKey] = TileLayerMetadata(ct, ld, ld.extent, crs, bounds)

    TemporalTiledRasterRDD(None, ContextRDD(rdd, metadata))
  }

  def display_raster(
    netcdfUri: String,
    extent: java.util.ArrayList[Double],
    day: Int,
    sc: SparkContext
  ) = {
    val List(xSliceStart, xSliceStop, ySliceStart, ySliceStop) = extentToIndices(extent)
    val xWidth = xSliceStop - xSliceStart + 1
    val yWidth = ySliceStop - ySliceStart + 1
    val xWidth2 = {
      val pow = math.ceil(math.log(xWidth)/math.log(2)).toInt
      1<<pow
    }
    val yWidth2 = {
      val pow = math.ceil(math.log(yWidth)/math.log(2)).toInt
      1<<pow
    }

    val ncfile = open(netcdfUri)
    val tasmin = ncfile.getVariables().get(3)
    val attribs = tasmin.getAttributes()
    val nodata = attribs.get(0).getValues().getFloat(0)

    val rdd: RDD[(SpatialKey, MultibandTile)] =
      sc.parallelize(List(day))
        .mapPartitions({ itr =>
          val ncfile = open(netcdfUri)
          val tasmin = ncfile.getVariables().get(3)
          val ucarType = tasmin.getDataType()

          itr.map({ t =>
            val key = SpatialKey(0, 0)
            val array = tasmin
              .read(s"$t,$ySliceStart:$ySliceStop,$xSliceStart:$xSliceStop")
              .get1DJavaArray(ucarType).asInstanceOf[Array[Float]]
            val tile = FloatUserDefinedNoDataArrayTile(array, xWidth, yWidth, FloatUserDefinedNoDataCellType(nodata)).rotate180.flipVertical
            val rtile = tile.resample(xWidth2, yWidth2)
            val mtile = ArrayMultibandTile(rtile)

            (key, mtile)
          })
        })
    val ct = FloatUserDefinedNoDataCellType(nodata)
    val tl = TileLayout(1, 1, xWidth2, yWidth2)
    val ld = LayoutDefinition(Extent(extent.get(0), extent.get(1), extent.get(2), extent.get(3)), tl)
    val crs = LatLng
    val bounds = KeyBounds[SpatialKey](
      SpatialKey(0, 0),
      SpatialKey(0, 0))
    val metadata: TileLayerMetadata[SpatialKey] = TileLayerMetadata(ct, ld, ld.extent, crs, bounds)

    SpatialTiledRasterRDD(None, ContextRDD(rdd, metadata))
  }

  def samples(
    netcdfUri: String,
    point: java.util.ArrayList[Double],
    days: java.util.ArrayList[Int],
    sc: SparkContext
  ) = {
    val List(xSlice, ySlice) = pointToIndices(point)
    val rdd = sc.parallelize(days.toList)
      .mapPartitions({ itr =>
        val ncfile = open(netcdfUri)
        val tasmin = ncfile.getVariables().get(3)
        val attribs = tasmin.getAttributes()
        val nodata = attribs.get(0).getValues().getFloat(0)
        val ucarType = tasmin.getDataType()

        itr.map({ t =>
          tasmin
            .read(s"$t,$ySlice,$xSlice")
            .getFloat(0)
        })
      })
    rdd
  }
}
