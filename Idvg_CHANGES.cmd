# ============================================================
# Sentaurus Device : Id-Vg at Vd = VDD = 1.0 V , Vg 0 -> 1.0 V
#   Ioff = Id at Vg = 0      Ion = Id at Vg = VDD
# To change VDD: edit the two Goal voltages marked (VDD)
# Result file : IdVg_IdVg_nMOSFET_des.plt
# ============================================================
File {
  Grid    = "nmos_final_fps.tdr"
  Plot    = "IdVg_nMOSFET"
  Current = "IdVg_nMOSFET"
  Output  = "IdVg_nMOSFET"
}

Electrode {
  { Name= "gate"   Voltage= 0.0 }
  { Name= "drain"  Voltage= 0.0 }
  { Name= "source" Voltage= 0.0 }
  { Name= "body"   Voltage= 0.0 }
}

Physics {
  Fermi
  EffectiveIntrinsicDensity( OldSlotboom )
  Mobility(
    DopingDep
    eHighFieldsaturation( GradQuasiFermi )
    hHighFieldsaturation( GradQuasiFermi )
    Enormal
  )
  Recombination(
    SRH( DopingDep TempDependence )
  )
}

Plot {
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  ElectricField/Vector Potential SpaceCharge
  Doping
  ConductionBand ValenceBand
}

Math {
  Extrapolate
  RelErrControl
  Digits= 5
  ErrRef(Electron)= 1.e10
  ErrRef(Hole)= 1.e10
  Iterations= 20
  Notdamped= 100
  Method= Blocked
  SubMethod= Super
  ACMethod= Blocked
  ACSubMethod= Super
  NumberOfThreads= 4
}

Solve {
  Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson }
  Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson Electron Hole }

  # Ramp drain to VDD with gate at 0
  Quasistationary(
    DoZero
    InitialStep= 0.02 Increment= 1.5
    MinStep= 1e-5 MaxStep= 0.2
    Goal { Name= "drain" Voltage= 1.0 }     * (VDD)
  ){ Coupled { Poisson Electron Hole } }

  # Gate sweep 0 -> VDD (DoZero saves the Vg = 0 point = Ioff)
  NewCurrentPrefix= "IdVg_"
  Quasistationary(
    DoZero
    InitialStep= 0.02 Increment= 1.5
    MinStep= 1e-5 MaxStep= 0.05
    Goal { Name= "gate" Voltage= 1.0 }      * (VDD)
  ){ Coupled { Poisson Electron Hole } }

  Plot( FilePrefix= "IdVg_final" )
}
