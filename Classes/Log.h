//
//  Log.h
//  DIS_KVC_KVO
//
//  Created by renjinkui on 2017/5/24.
//  Copyright © 2017年 JK. All rights reserved.
//

#ifndef Log_h
#define Log_h

static inline const char *log_extract_filename(const char *name) { char *p = strrchr(name, '/'); return p? p + 1 : name;}

#define __FILE_NAME__ log_extract_filename(__FILE__)

static inline void log_without_time(NSString *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    fprintf(stdout, "%s\n", [[NSString alloc] initWithFormat:fmt arguments:ap].autorelease.UTF8String);
    va_end(ap);
}

#define LOG_ON 0

#if LOG_ON
#define LOG_VERBOSE(fmt, tag, ...) log_without_time(@"%s file: \"%s>\" line: (%d) function: \"%s\" ==> \n<< \n\t"fmt@"\n>>\n",tag,__FILE_NAME__,__LINE__, __func__, ##__VA_ARGS__)
#else
#define LOG_VERBOSE(fmt, tag, ...)
#endif

#define LOG(fmt, ...)     LOG_VERBOSE(fmt, "****", ##__VA_ARGS__)
#define LOG_KVO(fmt, ...) LOG_VERBOSE(fmt, "**KVO**", ##__VA_ARGS__)
#define LOG_KVC(fmt, ...) LOG_VERBOSE(fmt, "**KVC**", ##__VA_ARGS__)

#define simple_desc(obj) ((obj) ? [NSString stringWithFormat:@"<%@, %p>", object_getClass(obj), (obj)] : @"null")
#define bool_desc(bo)    ((bo) ? @"YES" : @"NO")

#define LINE(line)   @"\t\t"line@"\n"
#define BRACE(lines) @"\t"@"{"@"\n"lines@"\t"@"}"


#endif /* Log_h */


