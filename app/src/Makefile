TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build an ioc application
# Use PROD_IOC_RTEMS for RTEMS only
# Use PROD_IOC_Linux for Linux only
PROD_IOC_Linux = lc20

# lc20.dbd will be created and installed
DBD += lc20.dbd

lc20_DBD += base.dbd
lc20_DBD += iocAdmin.dbd
lc20_DBD += asSupport.dbd
lc20_DBD += asyn.dbd
lc20_DBD += stream.dbd
lc20_DBD += modbus.dbd
lc20_DBD += modbusSupport.dbd
lc20_DBD += caPutLog.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
lc20_SRCS += lc20_registerRecordDeviceDriver.cpp
lc20_SRCS_DEFAULT += lc20Main.cpp

# Add locally compiled object code
#lc20_SRCS += dbSubExample.c

lc20_LIBS += stream
#lc20_LIBS += calc

lc20_LIBS += autosave
lc20_LIBS += devIocStats
lc20_LIBS += modbus
lc20_LIBS += caPutLog
lc20_LIBS += asyn
lc20_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

