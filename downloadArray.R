
require(downloader)
my.path="/pfs/out"

ftpdir <- "ftp://ftp.ebi.ac.uk//pub/databases/microarray/data/experiment/MTAB/E-MTAB-783/"
myfn <- file.path(my.path, "celfile_timestamp.RData")

message("Download genomic data")

require(R.utils) || stop("Library R.utils is not available!")

dir.create(file.path(my.path, "dwl"), showWarnings=FALSE, recursive=TRUE)

## download and compress CEL files
celfile.timestamp <- celfn <- NULL
i <- 1
while(i <= 9) {
## assuming there are only 9 zip archives (need to check if the update version has more)
dwl.status <- download.file(url=sprintf("%s/E-MTAB-783.raw.%i.zip", ftpdir, i), destfile=file.path(my.path, "dwl", sprintf("E-MTAB-783.raw.%i.zip", i)), quiet=TRUE)
	if(dwl.status != 0) {
		message("\t-> download failed, let's try again ...")
		file.remove(file.path(my.path, "dwl", sprintf("E-MTAB-783.raw.%i.zip", i)))
		i <- i - 1
		} else {
	## unzip archive
	fff <- unzip(zipfile=file.path(my.path, "dwl", sprintf("E-MTAB-783.raw.%i.zip", i)), list=TRUE)
	celfile.timestamp <- c(celfile.timestamp, as.character(fff[ ,"Date"]))
	celfn <- c(celfn, as.character(fff[ ,"Name"]))
	res <- unzip(zipfile=file.path(my.path, "dwl", sprintf("E-MTAB-783.raw.%i.zip", i)), exdir=my.path)
	## compress each CEL file individually using gzip
	library(R.utils)
	sapply(file.path(my.path, as.character(fff[ ,"Name"])), R.utils::gzip, overwrite=TRUE)
	i <- i + 1
	}
}
celfile.timestamp <- t(sapply(strsplit(celfile.timestamp, split=" "), function(x) { return(x) }))
dimnames(celfile.timestamp) <- list(celfn, c("file.day", "file.hour"))

# unlink(file.path(my.path, "dwl"), recursive=TRUE)
write.csv(celfile.timestamp, file=file.path(my.path, "celfile_timestamp.csv"))


## download sample information
message("Download sample information")
myfn <- file.path(my.path, "gdsc_ge_sampleinfo.txt")
  dir.create(file.path(my.path, "dwl"), showWarnings=FALSE, recursive=TRUE)
  dwl.status <- download.file(url=sprintf("%s/E-MTAB-783.sdrf.txt", ftpdir), destfile=file.path(my.path, "dwl", "E-MTAB-783.sdrf.txt"), quiet=TRUE)
  if(dwl.status != 0) { stop("Download failed, please rerun the pipeline!") }
  file.copy(from=file.path(my.path, "dwl", "E-MTAB-783.sdrf.txt"), to=myfn)
}

 unlink(file.path(my.path, "dwl"), recursive=T)