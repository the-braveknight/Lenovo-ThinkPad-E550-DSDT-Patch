// Keyboard configuration

DefinitionBlock("", "SSDT", 2, "hack", "KBD", 0)
{   
    // Enabling brightness keys
    External(_SB.PCI0.LPC.EC, DeviceObj)
    External(_SB.PCI0.LPC.KBD, DeviceObj)
    Scope(_SB.PCI0.LPC.EC) // brightness buttons
    {
        Method (_Q14) // Brightness down
        {
            Notify (KBD, 0x10)
        }
        
        Method (_Q15) // Btightness up
        {
            Notify (KBD, 0x20)
        }
    }
}
//EOF