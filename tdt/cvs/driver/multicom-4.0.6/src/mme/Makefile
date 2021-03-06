#*******************************************************************************
# Copyright (C) 2010   STMicroelectronics. All Rights Reserved.
# This file is part of the latest release of the Multicom4 project. This release 
# is fully functional and provides all of the original MME functionality.This 
# release  is now considered stable and ready for integration with other software 
# components.

 # Multicom4 is a free software; you can redistribute it and/or modify it under the 
# terms of the GNU General Public License as published by the Free Software Foundation 
# version 2.

# Multicom4 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with Multicom4; 
# see the file COPYING.  If not, write to the Free Software Foundation, 59 Temple Place - 
# Suite 330, Boston, MA 02111-1307, USA.

# Written by Multicom team at STMicroelectronics in November 2010.  
# Contact multicom.support@st.com. 
#*******************************************************************************

#
# Linux specific Makefile for MME subsystem module
#
#

ifneq ($(KERNELRELEASE),)

#
# Inside Linux kernel tree
#

obj-m   := mme.o mme_user.o

# MME specific CFLAGS
EXTRA_CFLAGS += -I$(obj)/../../include -I$(obj)/../ics/include -I$(obj)/include  $(DEBUG_CFLAGS) $(MULTICOM_EXTRA_CFLAGS)

mme-objs := \
	buffer/buffer.o \
	command/abort.o \
	command/command.o \
	command/kill.o \
	command/send.o \
	command/wait.o \
	debug/mme_debug.o \
	execution/execution.o \
	init/mme_init.o \
	init/term.o \
	linux/mme_module.o \
	manager/manager.o \
	manager/manager_client.o \
	memory/memory.o \
	messageq/messageq.o \
	msg/msg.o \
	receiver/receiver.o \
	transformer/alive.o \
	transformer/capability.o \
	transformer/cmd.o \
	transformer/instantiate.o \
	transformer/register.o \
	transformer/terminate.o \
	transformer/transformer.o \
	tune/tune.o \

mme_user-objs := \
	linux/mme_user_buffer.o \
	linux/mme_user_capability.o \
	linux/mme_user_command.o \
	linux/mme_user_help.o \
	linux/mme_user_module.o \
	linux/mme_user_send.o \
	linux/mme_user_transformer.o \
	linux/mme_user_wait.o \
	linux/mme_user_init.o \
	linux/mme_user_tuneable.o \

else

#
# Outside Linux kernel tree
#
PWD	     := $(shell pwd)

V            ?= 0

ARCH         ?= sh

CROSS_COMPILE ?= sh4-linux-

default:
	$(MAKE) V=$(V) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) O=$(O) SUBDIRS=$(PWD) modules

clean:
	$(MAKE) V=$(V) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) O=$(O) SUBDIRS=$(PWD) clean

endif
