// USBInjectAll configuration/override for ProBook 4x0s G2
//
// investigative work done by mo7a1995 (with direction from RehabMan)
//
// added HS08 for USB2 port reported not working by daniela-sammartino

DefinitionBlock ("", "SSDT", 2, "hack", "usb4x0g2", 0)
{
//
// Override for USBInjectAll.kext
//
    Device(UIAC)
    {
        Name(_HID, "UIA00000")
        Name(RMCF, Package()
        {
            // XHC overrides
            "8086_9xxx", Package()  // for G2 Haswell
            {
                //"port-count", Buffer() { 0x0d, 0, 0, 0},
                "ports", Package()
                {
                    "HS01", Package() // HS USB3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x01, 0, 0, 0 },
                    },
                    "HS02", Package() // HS USB3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x02, 0, 0, 0 },
                    },
                    "HS03", Package() // USB2
                    {
                        "UsbConnector", 0,
                        "port", Buffer() { 0x03, 0, 0, 0 },
                    },
                    "HS04", Package() // bluetooth
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x04, 0, 0, 0 },
                    },
                    #if 0
                    "HS05", Package() // fingerprint reader (disabled)
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x05, 0, 0, 0 },
                    },
                    #endif
                    "HS06", Package() // internal WWAN
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x06, 0, 0, 0 },
                    },
                    "HS07", Package() // camera
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x07, 0, 0, 0 },
                    },
                    "HS08", Package() // USB2
                    {
                        "UsbConnector", 0,
                        "port", Buffer() { 0x08, 0, 0, 0 },
                    },
                    // SSP1/SSP2 not used
                    "SSP3", Package() // SS USB3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x0c, 0, 0, 0 },
                    },
                    "SSP4", Package() // SS USB3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x0d, 0, 0, 0 },
                    },
                },
            },
            "8086_9cb1", Package() // for G2 Broadwell
            {
                //"port-count", Buffer() { 0x0f, 0, 0, 0},
                "ports", Package()
                {
                    "HS01", Package() // USB2 (right back)
                    {
                        "UsbConnector", 0,
                        "port", Buffer() { 0x01, 0, 0, 0 },
                    },
                    "HS02", Package() // HS USB3 (left front?)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x02, 0, 0, 0 },
                    },
                    "HS03", Package() // HS USB3 (left back)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x03, 0, 0, 0 },
                    },
                    "HS04", Package() // bluetooth
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x04, 0, 0, 0 },
                    },
                    #if 0
                    "HS05", Package() // fingerprint reader (disabled)
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x05, 0, 0, 0 },
                    },
                    #endif
                    "HS06", Package() // internal WWAN
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x06, 0, 0, 0 },
                    },
                    "HS07", Package() // camera
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x07, 0, 0, 0 },
                    },
                    "HS08", Package() // USB2 port (right front)
                    {
                        "UsbConnector", 0,
                        "port", Buffer() { 0x08, 0, 0, 0 },
                    },
                    //HS09 not used
                    "SSP1", Package() // SS USB3 (left front)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x0c, 0, 0, 0 },
                    },
                    "SSP2", Package() // SS USB3 (left back)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x0d, 0, 0, 0 },
                    },
                    //SSP3/SSP4 not used
                },
            },
        })
    }

//
// Disabling EHCI #1
//
    External(_SB.PCI0, DeviceObj)
    External(_SB.PCI0.LPCB, DeviceObj)
    External(_SB.PCI0.EH01, DeviceObj)

    // registers needed for disabling EHC#1
    Scope(_SB.PCI0.EH01)
    {
        OperationRegion(PSTS, PCI_Config, 0x54, 2)
        Field(PSTS, WordAcc, NoLock, Preserve)
        {
            PSTE, 2  // bits 2:0 are power state
        }
    }
    Scope(_SB.PCI0.LPCB)
    {
        OperationRegion(RMLP, PCI_Config, 0xF0, 4)
        Field(RMLP, DWordAcc, NoLock, Preserve)
        {
            RCB1, 32, // Root Complex Base Address
        }
        // address is in bits 31:14
        OperationRegion(FDM1, SystemMemory, (RCB1 & Not((1<<14)-1)) + 0x3418, 4)
        Field(FDM1, DWordAcc, NoLock, Preserve)
        {
            ,15,    // skip first 15 bits
            FDE1,1, // should be bit 15 (0-based) (FD EHCI#1)
        }
    }
    Scope(_SB.PCI0)
    {
        Device(RMD2)
        {
            //Name(_ADR, 0)
            Name(_HID, "RMD20000")
            Method(_INI)
            {
                // disable EHCI#1
                // put EHCI#1 in D3hot (sleep mode)
                ^^EH01.PSTE = 3
                // disable EHCI#1 PCI space
                ^^LPCB.FDE1 = 1
            }
        }
    }
}

//EOF