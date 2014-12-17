//
//  UZKFileInfo.m
//  UnzipKit
//
//

#import "UZKFileInfo.h"


@implementation UZKFileInfo



#pragma mark - Initialization


+ (instancetype) fileInfo:(unz_file_info *)fileInfo filename:(NSString *)filename {
    return [[UZKFileInfo alloc] initWithFileInfo:fileInfo filename:filename];
}

- (instancetype)initWithFileInfo:(unz_file_info *)fileInfo filename:(NSString *)filename
{
    if ((self = [super init])) {
        _filename = filename;
        _uncompressedSize = fileInfo->uncompressed_size;
        _compressedSize = fileInfo->compressed_size;
        _compressionMethod = [self readCompressionMethod:fileInfo->compression_method
                                                    flag:fileInfo->flag];
        _timestamp = [self readDate:&fileInfo->tmu_date];
        _CRC = fileInfo->crc;
        _isEncryptedWithPassword = (fileInfo->flag & 1) != 0;
    }
    return self;
}



#pragma mark - Private Methods


- (UZKCompressionMethod)readCompressionMethod:(uLong)compressionMethod
                                         flag:(uLong)flag
{
    UZKCompressionMethod level = UZKCompressionMethodNone;
    if (compressionMethod != 0) {
        switch ((flag & 0x6) / 2) {
            case 0:
                level = UZKCompressionMethodDefault;
                break;
                
            case 1:
                level = UZKCompressionMethodBest;
                break;
                
            default:
                level = UZKCompressionMethodFastest;
                break;
        }
    }
    
    return level;
}

- (NSDate *)readDate:(tm_unz *)date
{
    if (!date) {
        return nil;
    }
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day    = date->tm_mday;
    components.month  = date->tm_mon + 1;
    components.year   = date->tm_year;
    components.hour   = date->tm_hour;
    components.minute = date->tm_min;
    components.second = date->tm_sec;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar dateFromComponents:components];
}

@end
