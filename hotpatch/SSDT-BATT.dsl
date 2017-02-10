// Battery patches

DefinitionBlock ("", "SSDT", 2, "hack", "BATT", 0)
{
    
    External(_SB.PCI0.LPC.EC, DeviceObj)
    Scope(_SB.PCI0.LPC.EC)
    {
        OperationRegion (ERM2, EmbeddedControl, Zero, 0x0100)
        Field (ERM2, ByteAcc, Lock, Preserve)
        {
            Offset(0x4E),
            AK00, 8, AK01, 8,
        }
        Field (ERM2, ByteAcc, Lock, Preserve)
        {
            Offset (0xA0),
            RC00, 8, RC01, 8, 
            FC00, 8, FC01, 8,
            Offset(0xA8),
            AC00, 8, AC01, 8, 
            BV00, 8, BV01, 8,
        }
        Field (ERM2, ByteAcc, Lock, Preserve)
        {
            Offset(0xA0),
            BM00, 8, BM01, 8,
        }
        Field (ERM2, ByteAcc, Lock, Preserve)
        {
            Offset(0xA0),
            DC00, 8, DC01, 8, 
            DV00, 8, DV01, 8,
            Offset(0xA7),
            SN00, 8, SN01, 8,
        }
        Field (ERM2, ByteAcc, Lock, Preserve)
        {
            Offset(0xA0),
            CH00, 8, CH01, 8, CH02, 8, CH03, 8,
        }
        
        External(HIID, FieldUnitObj)
        External(BATM, MutexObj)
        Method (GBIF, 3, NotSerialized)
        {
            Acquire (BATM, 0xFFFF)
            If (Arg2)
            {
                Or (Arg0, One, HIID)
                Store (B1B2(BM00,BM01), Local7)
                ShiftRight (Local7, 0x0F, Local7)
                XOr (Local7, One, Index (Arg1, Zero))
                Store (Arg0, HIID)
                If (Local7)
                {
                    Multiply (B1B2(FC00,FC01), 0x0A, Local1)
                }
                Else
                {
                    Store (B1B2(FC00,FC01), Local1)
                }

                Store (Local1, Index (Arg1, 0x02))
                Or (Arg0, 0x02, HIID)
                If (Local7)
                {
                    Multiply (B1B2(DC00,DC01), 0x0A, Local0)
                }
                Else
                {
                    Store (B1B2(DC00,DC01), Local0)
                }

                Store (Local0, Index (Arg1, One))
                Divide (Local1, 0x14, Local2, Index (Arg1, 0x05))
                If (Local7)
                {
                    Store (0xC8, Index (Arg1, 0x06))
                }
                ElseIf (B1B2(DV00,DV01))
                {
                    Divide (0x00030D40, B1B2(DV00,DV01), Local2, Index (Arg1, 0x06))
                }
                Else
                {
                    Store (Zero, Index (Arg1, 0x06))
                }

                Store (B1B2(DV00,DV01), Index (Arg1, 0x04))
                Store (B1B2(SN00,SN01), Local0)
                Name (SERN, Buffer (0x06)
                {
                    "     "
                })
                Store (0x04, Local2)
                While (Local0)
                {
                    Divide (Local0, 0x0A, Local1, Local0)
                    Add (Local1, 0x30, Index (SERN, Local2))
                    Decrement (Local2)
                }

                Store (SERN, Index (Arg1, 0x0A))
                Or (Arg0, 0x06, HIID)
                Store (RECB(0xA0,128), Index (Arg1, 0x09))
                Or (Arg0, 0x04, HIID)
                Name (BTYP, Buffer (0x05)
                {
                    0x00, 0x00, 0x00, 0x00, 0x00                   
                })
                Store (B1B4(CH00,CH01,CH02,CH03), BTYP)
                Store (BTYP, Index (Arg1, 0x0B))
                Or (Arg0, 0x05, HIID)
                Store (RECB(0xA0,128), Index (Arg1, 0x0C))
            }
            Else
            {
                Store (Ones, Index (Arg1, One))
                Store (Zero, Index (Arg1, 0x05))
                Store (Zero, Index (Arg1, 0x06))
                Store (Ones, Index (Arg1, 0x02))
            }

            Release (BATM)
            Return (Arg1)
        }
        
        Method (GBST, 4, NotSerialized)
        {
            Acquire (BATM, 0xFFFF)
            If (And (Arg1, 0x20))
            {
                Store (0x02, Local0)
            }
            ElseIf (And (Arg1, 0x40))
            {
                Store (One, Local0)
            }
            Else
            {
                Store (Zero, Local0)
            }

            If (And (Arg1, 0x07)) {}
            Else
            {
                Or (Local0, 0x04, Local0)
            }

            If (LEqual (And (Arg1, 0x07), 0x07))
            {
                Store (0x04, Local0)
                Store (Zero, Local1)
                Store (Zero, Local2)
                Store (Zero, Local3)
            }
            Else
            {
                Store (Arg0, HIID)
                Store (B1B2(BV00,BV01), Local3)
                If (Arg2)
                {
                    Multiply (B1B2(RC00,RC01), 0x0A, Local2)
                }
                Else
                {
                    Store (B1B2(RC00,RC01), Local2)
                }

                Store (B1B2(AC00,AC01), Local1)
                If (LGreaterEqual (Local1, 0x8000))
                {
                    If (And (Local0, One))
                    {
                        Subtract (0x00010000, Local1, Local1)
                    }
                    Else
                    {
                        Store (Zero, Local1)
                    }
                }
                ElseIf (LNot (And (Local0, 0x02)))
                {
                    Store (Zero, Local1)
                }

                If (Arg2)
                {
                    Multiply (Local3, Local1, Local1)
                    Divide (Local1, 0x03E8, Local7, Local1)
                }
            }

            Store (Local0, Index (Arg3, Zero))
            Store (Local1, Index (Arg3, One))
            Store (Local2, Index (Arg3, 0x02))
            Store (Local3, Index (Arg3, 0x03))
            Release (BATM)
            Return (Arg3)
        }
        
        
        
        
        Method (RE1B, 1, NotSerialized)
        // Arg0 - offset in bytes from zero-based EC
        {
            OperationRegion(ERM2, EmbeddedControl, Arg0, 1)
            Field(ERM2, ByteAcc, NoLock, Preserve) { BYTE, 8 }
            Return(BYTE)
        }
        
        Method (RECB, 2, Serialized)
        // Arg0 - offset in bytes from zero-based EC
        // Arg1 - size of buffer in bits
        {
            ShiftRight(Arg1, 3, Arg1)
            Name(TEMP, Buffer(Arg1) { })
            Add(Arg0, Arg1, Arg1)
            Store(0, Local0)
            While (LLess(Arg0, Arg1))
            {
                Store(RE1B(Arg0), Index(TEMP, Local0))
                Increment(Arg0)
                Increment(Local0)
            }
            Return(TEMP)
        }
    }
    
    Scope(_GPE)
    {
        Method (_L0D, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            Store (B1B2(\_SB.PCI0.LPC.EC.AK00,\_SB.PCI0.LPC.EC.AK01), Local0)
           // Store (\_SB.PCI0.LPC.EC.HWAK, Local0)
            Store (Local0, RRBF)
            Sleep (0x0A)
            If (And (Local0, 0x02)) {}
            If (And (Local0, 0x04))
            {
                Notify (\_SB.LID, 0x02)
            }

            If (And (Local0, 0x08))
            {
                Notify (\_SB.LID, 0x02)
            }

            If (And (Local0, 0x10))
            {
                Notify (\_SB.LID, 0x02)
            }

            If (And (Local0, 0x40)) {}
            If (And (Local0, 0x80))
            {
                Notify (\_SB.LID, 0x02)
            }

            Store (Zero, B1B2(\_SB.PCI0.LPC.EC.AK00,\_SB.PCI0.LPC.EC.AK01))
           // Store (B1B2(\_SB.PCI0.LPC.EC.AK00,\_SB.PCI0.LPC.EC.AK01), Local0)
        }
    }
    
    External(D80P, FieldUnitObj)
    External(WAKI, PkgObj)
    External(SPS, BuffObj)
    External(_SB.PCI0.LPC.EC.HCMU, FieldUnitObj)
    External(_SB.PCI0.LPC.EC.EVNT, MethodObj)
    External(_SB.PCI0.LPC.EC.HKEY.MHKE, MethodObj)
    External(_SB.PCI0.LPC.EC.FNST, MethodObj)
    External(UCMS, MethodObj)
    External(LIDB, FieldUnitObj)
    External(_SB.PCI0.LPC.EC.HFNI, FieldUnitObj)
    External(FNID, BuffObj)
    External(NVSS, MethodObj)
    External(_SB.PCI0.LPC.EC.AC._PSR, MethodObj)
    External(PWRS, FieldUnitObj)
    External(OSC4, FieldUnitObj)
    External(PNTF, MethodObj)
    External(ACST, BuffObj)
    External(_SB.PCI0.LPC.EC.ATMC, MethodObj)
    External(SCRM, FieldUnitObj)
    External(_SB.PCI0.LPC.EC.HFSP, FieldUnitObj)
    External(IOEN, FieldUnitObj)
    External(IOST, FieldUnitObj)
    External(ISWK, FieldUnitObj)
    External(_SB.PCI0.LPC.EC.HKEY.DHKC, BuffObj)
    External(_SB.PCI0.LPC.EC.HKEY.MHKQ, MethodObj)
    External(FFCL, FieldUnitObj)
    External(IFRS, MethodObj)
    External(VIGD, FieldUnitObj)
    External(_SB.PCI0.VID.GLIS, MethodObj)
    External(_SB.LID._LID, MethodObj)
    External(WVIS, BuffObj)
    External(VBTD, MethodObj)
    External(VCMS, MethodObj)
    External(AWON, MethodObj)
    External(CMPR, FieldUnitObj)
    External(USBR, FieldUnitObj)
    External(_SB.PCI0.XHC.XRST, BuffObj)
    External(_SB.PCI0.XHC.PR3, FieldUnitObj)
    External(_SB.PCI0.XHC.PR3M, FieldUnitObj)
    External(_SB.PCI0.XHC.PR2, FieldUnitObj)
    External(_SB.PCI0.XHC.PR2M, FieldUnitObj)
    External(_SB.PCI0.LPC.EC.HSPA, FieldUnitObj)
    External(NBCF, BuffObj)
    External(_SB.PCI0.LPC.EC.BRNS, MethodObj)
    External(VBRC, MethodObj)
    External(BRLV, FieldUnitObj)
    External(AUDC, MethodObj)
    External(F1LD, FieldUnitObj)
    External(_SB.PCI0.LPC.EC.BATW, MethodObj)
    External(_SB.PCI0.LPC.EC.HKEY.WGWK, MethodObj)
    External(_TZ.THM0, ThermalZoneObj)
    External(VSLD, MethodObj)
    External(RRBF, BuffObj)
    External(CSUM, MethodObj)
    External(CHKC, FieldUnitObj)
    External(CHKE, FieldUnitObj)
    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        ShiftLeft (Arg0, 0x04, D80P)
        If (LOr (LEqual (Arg0, Zero), LGreaterEqual (Arg0, 0x05)))
        {
            Return (WAKI)
        }

        Store (Zero, SPS)
        Store (Zero, \_SB.PCI0.LPC.EC.HCMU)
        \_SB.PCI0.LPC.EC.EVNT (One)
        \_SB.PCI0.LPC.EC.HKEY.MHKE (One)
        \_SB.PCI0.LPC.EC.FNST ()
        UCMS (0x0D)
        Store (Zero, LIDB)
        If (LEqual (Arg0, One))
        {
            Store (\_SB.PCI0.LPC.EC.HFNI, FNID)
        }

        If (LEqual (Arg0, 0x03))
        {
            NVSS (Zero)
            Store (\_SB.PCI0.LPC.EC.AC._PSR (), PWRS)
            If (OSC4)
            {
                PNTF (0x81)
            }

            If (LNotEqual (ACST, \_SB.PCI0.LPC.EC.AC._PSR ()))
            {
                \_SB.PCI0.LPC.EC.ATMC ()
            }

            If (SCRM)
            {
                Store (0x07, \_SB.PCI0.LPC.EC.HFSP)
            }

            Store (Zero, IOEN)
            Store (Zero, IOST)
            If (LEqual (ISWK, One))
            {
                If (\_SB.PCI0.LPC.EC.HKEY.DHKC)
                {
                    \_SB.PCI0.LPC.EC.HKEY.MHKQ (0x6070)
                }
            }

            If (FFCL)
            {
                IFRS (0x03, Zero)
            }

            If (VIGD)
            {
                \_SB.PCI0.VID.GLIS (\_SB.LID._LID ())
                If (WVIS)
                {
                    VBTD ()
                }
            }
            ElseIf (WVIS)
            {
                \_SB.PCI0.VID.GLIS (\_SB.LID._LID ())
                VBTD ()
            }

            VCMS (One, \_SB.LID._LID ())
            AWON (Zero)
            If (CMPR)
            {
                Notify (\_SB.LID, 0x02)
                Store (Zero, CMPR)
            }

            If (LOr (USBR, \_SB.PCI0.XHC.XRST))
            {
                If (LOr (LEqual (\_SB.PCI0.XHC, 0x02), LEqual (\_SB.PCI0.XHC, 0x03)))
                {
                    Store (Zero, Local0)
                    And (\_SB.PCI0.XHC.PR3, 0xFFFFFFC0, Local0)
                    Or (Local0, \_SB.PCI0.XHC.PR3M, \_SB.PCI0.XHC.PR3)
                    Store (Zero, Local0)
                    And (\_SB.PCI0.XHC.PR2, 0xFFFF8000, Local0)
                    Or (Local0, \_SB.PCI0.XHC.PR2M, \_SB.PCI0.XHC.PR2)
                }
            }
        }

        If (LEqual (Arg0, 0x04))
        {
            NVSS (Zero)
            Store (Zero, \_SB.PCI0.LPC.EC.HSPA)
            Store (\_SB.PCI0.LPC.EC.AC._PSR (), PWRS)
            If (OSC4)
            {
                PNTF (0x81)
            }

            \_SB.PCI0.LPC.EC.ATMC ()
            If (SCRM)
            {
                Store (0x07, \_SB.PCI0.LPC.EC.HFSP)
            }

            If (LNot (NBCF))
            {
                If (VIGD)
                {
                    \_SB.PCI0.LPC.EC.BRNS ()
                }
                Else
                {
                    VBRC (BRLV)
                }
            }

            Store (AUDC (Zero, Zero), Local0)
            And (Local0, One, Local0)
            If (LEqual (Local0, Zero))
            {
                Store (One, F1LD)
            }
            Else
            {
                Store (Zero, F1LD)
            }

            Store (Zero, IOEN)
            Store (Zero, IOST)
            If (LEqual (ISWK, 0x02))
            {
                If (\_SB.PCI0.LPC.EC.HKEY.DHKC)
                {
                    \_SB.PCI0.LPC.EC.HKEY.MHKQ (0x6080)
                }
            }

            If (\_SB.PCI0.XHC.XRST)
            {
                If (LOr (LEqual (\_SB.PCI0.XHC, 0x02), LEqual (\_SB.PCI0.XHC, 0x03)))
                {
                    Store (Zero, Local0)
                    And (\_SB.PCI0.XHC.PR3, 0xFFFFFFC0, Local0)
                    Or (Local0, \_SB.PCI0.XHC.PR3M, \_SB.PCI0.XHC.PR3)
                    Store (Zero, Local0)
                    And (\_SB.PCI0.XHC.PR2, 0xFFFF8000, Local0)
                    Or (Local0, \_SB.PCI0.XHC.PR2M, \_SB.PCI0.XHC.PR2)
                }
            }
        }

        \_SB.PCI0.LPC.EC.BATW (Arg0)
        \_SB.PCI0.LPC.EC.HKEY.WGWK (Arg0)
        Notify (\_TZ.THM0, 0x80)
        VSLD (\_SB.LID._LID ())
        If (VIGD)
        {
            \_SB.PCI0.VID.GLIS (\_SB.LID._LID ())
        }
        ElseIf (WVIS)
        {
            \_SB.PCI0.VID.GLIS (\_SB.LID._LID ())
        }

        If (LLess (Arg0, 0x04))
        {
            If (LOr (And (RRBF, 0x02), And (B1B2(\_SB.PCI0.LPC.EC.AK00,\_SB.PCI0.LPC.EC.AK01), 0x02)))
            {
                ShiftLeft (Arg0, 0x08, Local0)
                Store (Or (0x2013, Local0), Local0)
                \_SB.PCI0.LPC.EC.HKEY.MHKQ (Local0)
            }
        }

        If (LEqual (Arg0, 0x04))
        {
            Store (Zero, Local0)
            Store (CSUM (Zero), Local1)
            If (LNotEqual (Local1, CHKC))
            {
                Store (One, Local0)
                Store (Local1, CHKC)
            }

            Store (CSUM (One), Local1)
            If (LNotEqual (Local1, CHKE))
            {
                Store (One, Local0)
                Store (Local1, CHKE)
            }

            If (Local0)
            {
                Notify (_SB, Zero)
            }
        }
        
        Store (Zero, B1B2(\_SB.PCI0.LPC.EC.AK00,\_SB.PCI0.LPC.EC.AK01))
        Store (Zero, RRBF)
        ShiftLeft (Arg0, 0x04, Local2)
        Or (Local2, 0x0E, Local2)
        Store (Local2, D80P)
        Return (WAKI)
    }
    
    Method (B1B2, 2, NotSerialized) { Return(Or(Arg0, ShiftLeft(Arg1, 8))) }
    
    Method (B1B4, 4, NotSerialized)
    {
        Store(Arg3, Local0)
        Or(Arg2, ShiftLeft(Local0, 8), Local0)
        Or(Arg1, ShiftLeft(Local0, 8), Local0)
        Or(Arg0, ShiftLeft(Local0, 8), Local0)
        Return(Local0)
    }
}

//EOF