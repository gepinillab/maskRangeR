#=========================================================================================
#=======================================================================================
#' @importFrom magrittr %>%
.reDate <- function(datedOccs, dateScale){
  long=lat=date=parse_date_time=ymd=year=month=day=NULL # trick for check
  if(dateScale == "year"){
    out=datedOccs %>% dplyr::select(long,lat,date) %>%
      dplyr::mutate(date = as.Date(paste0(date, "-01-01"))) %>%
      dplyr::mutate(years = lubridate::year(date))
  }
  if(dateScale == "month"){
    out=datedOccs %>% dplyr::select(long,lat,date) %>%
      dplyr::mutate(date = parse_date_time(date, "ym")) %>%
      dplyr::mutate(months = lubridate::month(date)) %>%
      dplyr::mutate(years = lubridate::year(date))
  }
  if(dateScale == "day"){
    out=datedOccs %>% dplyr::select(long,lat,date) %>%
      dplyr::mutate(date = lubridate::ymd(date)) %>%
      dplyr::mutate(years = lubridate::year(date)) %>% 
      dplyr::mutate(months = lubridate::month(date)) %>%
      dplyr::mutate(days = lubridate::day(date))
  }
  return(out)
}

#=========================================================================================
#=======================================================================================
#' @importFrom magrittr %>%
.uniDates<-function(occ1, dateScale){
  years=days=NULL # trick for check
  if (dateScale == "year"){
    out=dplyr::arrange(unique(dplyr::select(occ1, years)), years)
  } 
  if (dateScale == "month"){
    out=dplyr::arrange(unique(dplyr::select(occ1, years, months)), years)
  } 
  if (dateScale == "day"){
    out=dplyr::arrange(unique(dplyr::select(occ1, years, months, days)), years)
  }
  return(out)
}
#=========================================================================================
#=======================================================================================
#' @importFrom magrittr %>%
.parseDate <- function(dateScale, occ1, uniqueDates){
  years=days=NULL # trick for check
  t1 <- NULL
  if (dateScale == "year"){
    for (i in 1:nrow(uniqueDates)){
      t1[[i]] = dplyr::filter(occ1, years == as.list(uniqueDates)$years[[i]])
    }}
  #### NEED TO FIGURE OUT YEAR MONTH DAY COMBINATIONS
  if (dateScale == "month"){
    t1 <- NULL
    for (i in 1:nrow(uniqueDates)){
      t1[[i]] = dplyr::filter(occ1, months == as.list(uniqueDates)$years[[i]])
    }}
  
  if (dateScale == "day"){
    t1 <- NULL
    for (i in 1:nrow(uniqueDates)){
      t1[[i]] = dplyr::filter(occ1, days == as.list(uniqueDates)$years[[i]])
    }}
  return(t1)
}
#=========================================================================================
#=======================================================================================
#' @importFrom magrittr %>%
.valExtract <- function(occ3, RSenv){
  lat=long=NULL # trick for check
  occ4 <- lapply(occ3, function(x) x %>% dplyr::select(long, lat))
  vals <- mapply(raster::extract, raster::unstack(RSenv), occ4)
  lowerBound <- min(unlist(vals))
  upperBound <- max(unlist(vals))
  out=as.data.frame(cbind(lowerBound, upperBound))
  return(out)
}

#=========================================================================================
#=======================================================================================
.dataMask <- function(RSenv, ulBounds, Model, Bounds){
  if(Bounds == "both"){
    RSenvCrop <- raster::crop(RSenv, raster::extent(Model))
    modelCrop <- raster::crop(Model, raster::extent(RSenvCrop))
    rasterMask <- RSenvCrop[[raster::nlayers(RSenvCrop)]]
    rasterMask[rasterMask < ulBounds$lowerBound] <- NA
    rasterMask[rasterMask > ulBounds$upperBound] <- NA
    return(raster::mask(modelCrop, rasterMask))
  }
  if(Bounds == "upper"){
    RSenvCrop <- raster::crop(RSenv, raster::extent(Model))
    modelCrop <- raster::crop(Model, raster::extent(RSenvCrop))
    rasterMask <- RSenvCrop[[raster::nlayers(RSenvCrop)]]
    rasterMask[rasterMask < ulBounds$upperBound] <- NA
    return(raster::mask(modelCrop, rasterMask))
  }
  if(Bounds == "lower"){
    RSenvCrop <- raster::crop(RSenv, raster::extent(Model))
    modelCrop <- raster::crop(Model, raster::extent(RSenvCrop))
    rasterMask <- RSenvCrop[[raster::nlayers(RSenvCrop)]]
    rasterMask[rasterMask < ulBounds$lowerBound] <- NA
    return(raster::mask(modelCrop, rasterMask))
  }
}