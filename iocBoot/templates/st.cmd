#!$$IOCTOP/bin/$$IF(ARCH,$$ARCH,linux-x86_64)/setra

< envPaths
epicsEnvSet( "ENGINEER" , "$$ENGINEER" )
epicsEnvSet( "IOCSH_PS1", "$$IOCNAME>" )
epicsEnvSet( "IOC_PV",    "$$IOC_PV"   )
epicsEnvSet( "LOCATION",  "$$IF(LOCATION,$$LOCATION,$$IOC_PV)")
epicsEnvSet( "IOCTOP",    "$$IOCTOP"   )
epicsEnvSet( "TOP",       "$$TOP"      )

cd( "$(IOCTOP)" )

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Register all support components
dbLoadDatabase("dbd/setra.dbd")

setra_registerRecordDeviceDriver(pdbbase)

# Set this to enable LOTS of stream module diagnostics
#var streamDebug 1

# Configure each device

$$LOOP(SETRA)
drvAsynIPPortConfigure( "SETRA$$INDEX", "$$HOST:502 TCP", 0, 0, 1 )
modbusInterposeConfig("SETRA$$INDEX",0,5000,0)
$$ENDLOOP(SETRA)

# Register definitions are From Setra modbus datasheet go as followed
#
# Setra$(N)_set_reg-  Writes to device a register #8000. Used to read snapshot of Setra_read_register records.
#
# Setra$(N)_samp_reg- ReadWrite device registers #5000-#5032.
#
# Setra$(N)_read_reg- ReadWrite device registers #9000-#9085. 
 

# drvModbusAsynConfigure(modbusPort,  asynPort,  slave address, modbus_function, offset, data_length,
#                        data_type, timeout, debug name)

$$LOOP(SETRA)
drvModbusAsynConfigure(  "Setra$$(INDEX)_set_reg",  "SETRA$$INDEX",  247,  16,  8000,   4,  0,  1000, "SETRA$$(INDEX)_Set")
drvModbusAsynConfigure(  "Setra$$(INDEX)_samp_reg", "SETRA$$INDEX",  247,  16,  5000,  32,  0,  1000, "SETRA$$(INDEX)_Samp")
drvModbusAsynConfigure(  "Setra$$(INDEX)_read_reg", "SETRA$$INDEX",  247,   3,  9000,  85,  0,  3000, "SETRA$$(INDEX)_Read")

# USED AS DEBUGGING TOOL
#asynSetTraceMask("Setra$$(INDEX)_set_reg", 0, 9)
#asynSetTraceMask("Setra$$(INDEX)_read_register", 0, 9)
#asynSetTraceIOMask("SETRA$$INDEX", 0, 4)
#asynSetTraceMask("SETRA$$INDEX", 0, 9) 

# Send trace output to motor specific log files
#asynSetTraceFile(   "SETRA$$INDEX", 0, "/reg/d/iocData/$(IOC)/logs/SETRA$$INDEX.log" )
#asynSetTraceFile(   "SETRA$$(INDEX)_Read)", 0, "/reg/d/iocData/$(IOC)/logs/SETRA$$(INDEX)_Read).log" )
$$ENDLOOP(SETRA)

# Load record instances

dbLoadRecords( "db/iocSoft.db",            "IOC=$(IOCPV)" )
dbLoadRecords( "db/save_restoreStatus.db", "P=$(IOCPV):" )
$$LOOP(SETRA)
dbLoadRecords( "db/setra.db",       "DEV=$$BASE,N=$$(INDEX)" )
#dbLoadRecords( "db/asynRecord.db", "Dev=NAME, PORT=PORT")
$$ENDLOOP(SETRA)

# Setup autosave
set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave")
set_requestfile_path( "$(TOP)/autosave")
save_restoreSet_status_prefix( "$(IOC_PV)" )
save_restoreSet_IncompleteSetsOk( 1 )
save_restoreSet_DatedBackupFiles( 1 )

# Just restore the settings
set_pass0_restoreFile( "$(IOC).sav" )
set_pass1_restoreFile( "$(IOC).sav" )

# Initialize the IOC and start processing records
iocInit()

# Start autosave backups
create_monitor_set( "$(IOC).req", 5, "" )

# All IOCs should dump some common info after initial startup.
< /reg/d/iocCommon/All/post_linux.cmd



