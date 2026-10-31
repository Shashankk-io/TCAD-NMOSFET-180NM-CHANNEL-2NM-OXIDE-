# ============================================================
# Sentaurus Device : Id-Vd at Vg = VDD = 1.0 V , Vd 0 -> 1.0 V
# Result file : IdVd_IdVd_nMOSFET_des.plt
# ============================================================
File {
  Grid    = "nmos_final_fps.tdr"
  Plot    = "IdVd_nMOSFET"
  Current = "IdVd_nMOSFET"
  Output  = "IdVd_nMOSFET"
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

  # Ramp gate to VDD with drain at 0
  Quasistationary(
    DoZero
    InitialStep= 0.02 Increment= 1.5
    MinStep= 1e-5 MaxStep= 0.2
    Goal { Name= "gate" Voltage= 1.0 }      * (VDD)
  ){ Coupled { Poisson Electron Hole } }

  # Drain sweep 0 -> VDD
  NewCurrentPrefix= "IdVd_"
  Quasistationary(
    DoZero
    InitialStep= 0.02 Increment= 1.5
    MinStep= 1e-5 MaxStep= 0.05
    Goal { Name= "drain" Voltage= 1.0 }     * (VDD)
  ){ Coupled { Poisson Electron Hole } }

  Plot( FilePrefix= "IdVd_final" )
}
