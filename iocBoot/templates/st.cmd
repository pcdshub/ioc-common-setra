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

# Bump up queue sizes!
scanOnceSetQueueSize(4000)
callbackSetQueueSize(4000)

# Configure each device

$$LOOP(SETRA)
drvAsynIPPortConfigure( "SETRA$$INDEX", "$$HOST:502 TCP", 0, 0, 1 )
modbusInterposeConfig("SETRA$$INDEX",0,5000,0)
$$IF(DEBUG,,#)asynSetTraceIOMask("SETRA$$INDEX", 0, 4)
$$IF(DEBUG,,#)asynSetTraceMask("SETRA$$INDEX", 0, 9) 
$$IF(LOG,,#)asynSetTraceFile("SETRA$$INDEX", 0, "/reg/d/iocData/$(IOC)/logs/SETRA$$INDEX.log" )
$$ENDLOOP(SETRA)

# Register definitions are From Setra modbus datasheet go as followed
#
# Setra$(N)_set_write-  Writes to device a register #8000. Used to read snapshot of Setra_read_register records.
#
# Setra$(N)_samp_read/write- Read/Write device registers #5000-#5032.
#
# Setra$(N)_data_read - Read device registers #9000-#9085. 

# drvModbusAsynConfigure(modbusPort,                 asynPort,     slave, func, offset, length, type, polltime, debugname)

$$LOOP(SETRA)
drvModbusAsynConfigure(  "Setra$$(INDEX)_chan_cnt",  "SETRA$$INDEX",  247,   3,  1036,   1,  0,  5000, "SETRA$$(INDEX)_RegCnt")
drvModbusAsynConfigure(  "Setra$$(INDEX)_chan_en",   "SETRA$$INDEX",  247,   3,  6000,   6,  0,  5000, "SETRA$$(INDEX)_ChEn")
drvModbusAsynConfigure(  "Setra$$(INDEX)_chan_size", "SETRA$$INDEX",  247,   3,  6100,  12,  0,  5000, "SETRA$$(INDEX)_ChSize")
drvModbusAsynConfigure(  "Setra$$(INDEX)_chan_pm",   "SETRA$$INDEX",  247,   3, 10900,  12,  0,  5000, "SETRA$$(INDEX)_PartMass")
drvModbusAsynConfigure(  "Setra$$(INDEX)_chan_tpm",  "SETRA$$INDEX",  247,   3, 11700,  12,  0,  5000, "SETRA$$(INDEX)_TotPartMass")
drvModbusAsynConfigure(  "Setra$$(INDEX)_set_write", "SETRA$$INDEX",  247,  16,  8000,   4,  0,  5000, "SETRA$$(INDEX)_Set")
drvModbusAsynConfigure(  "Setra$$(INDEX)_samp_read", "SETRA$$INDEX",  247,   3,  5000,  15,  0,  5000, "SETRA$$(INDEX)_SampR")
drvModbusAsynConfigure(  "Setra$$(INDEX)_samp_write","SETRA$$INDEX",  247,  16,  5000,  15,  0,  5000, "SETRA$$(INDEX)_SampW")
drvModbusAsynConfigure(  "Setra$$(INDEX)_data_read", "SETRA$$INDEX",  247,   3,  9000,  85,  0,  5000, "SETRA$$(INDEX)_Read")

$$IF(RLOG,,#)asynSetTraceFile("SETRA$$(INDEX)_Read", 0, "/reg/d/iocData/$(IOC)/logs/SETRA$$(INDEX)_Read.log" )
$$ENDLOOP(SETRA)

# Load record instances

dbLoadRecords( "db/iocSoft.db",            "IOC=$(IOC_PV)" )
dbLoadRecords( "db/save_restoreStatus.db", "P=$(IOC_PV):" )
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
