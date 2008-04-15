/*
 * Copyright (c) 1998, Brian Cully <shmit@kublai.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The names of contributers to this software may not be used to endorse
 *    or promote products derived from this software without specific
 *    prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "BuffIO.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

@implementation BuffIO
-init: (const char *)fileName
{
	struct stat sb;
	int confFd;

	confFd = open(fileName, O_RDONLY, 0);
	if (confFd == -1) {
		fprintf(stderr, "ERROR: couldn't open config file %s: %s.\n",
			fileName, strerror(errno));
		return nil;
	}
	if (fstat(confFd, &sb) == -1) {
		fprintf(stderr, "ERROR: couldn't stat config file %s: %s.\n",
			fileName, strerror(errno));
		return nil;
	}
	fileLen = sb.st_size;
	file = mmap(NULL, fileLen, PROT_READ, MAP_PRIVATE, confFd, 0);
	if (file == MAP_FAILED) {
		fprintf(stderr, "ERROR: couldn't mmap config file %s: %s.\n",
			fileName, strerror(errno));
		return nil;
	}
	close(confFd);

	curOff = file;
	EOL = '\n';

	return self;
}

-free
{
	munmap(file, fileLen);
	return [super free];
}

-(char *)
getCurOff
{
	return curOff;
}

-(off_t)
getLength
{
	return fileLen;
}

-setEOL: (char)delim
{
	EOL = delim;
	return self;
}
@end
